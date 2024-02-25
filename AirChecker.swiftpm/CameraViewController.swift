import UIKit
import AVFoundation
import Vision

class CameraViewController: UIViewController {
    
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    private var cameraFeedSession: AVCaptureSession?
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    
    private var evidenceBuffer = [HandGestureProcessor.PointsPair]()
    private var isFirstSegment = true
    private var lastObservationTimestamp = Date()
    
    private var gestureProcessor = HandGestureProcessor()
    
    private var rowRanges: [(start: CGFloat, end: CGFloat)] = []
    private var columnRanges: [(start: CGFloat, end: CGFloat)] = []
    
    private var floatingCheckerView: Checker?
    
    private var isPinching: Bool = false
    private var isHolding: Bool = false
    private var previousState: HandGestureProcessor.State = .unknown
    
    private var cameraView: CameraView { view as! CameraView }
    private var chessBoardView: ChessBoardView!
    
    private var movableCheckers: [[Int]] = [[5, 0],[5,2],[5, 4],[5,6]]
    
    
    override func loadView() {
        view = CameraView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if chessBoardView == nil { // Ensure it's only set up once
            let boardSize = min(view.bounds.width, view.bounds.height) * 0.8
            chessBoardView = ChessBoardView(frame: CGRect(x:0, y:0, width:boardSize, height:boardSize))
            chessBoardView.center = view.center
            view.addSubview(chessBoardView)
            view.bringSubviewToFront(chessBoardView)
            calculateBoardCoordinates()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handPoseRequest.maximumHandCount = 1
        gestureProcessor.didChangeStateClosure = { [weak self] state in
            self?.handleGestureStateChange(state: state)
        }
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        recognizer.numberOfTouchesRequired = 1
        recognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(recognizer)
        initializeCheckersGameFrom2DArray()
        createSelectedCheckerView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            if cameraFeedSession == nil {
                cameraView.previewLayer.videoGravity = .resizeAspectFill
                try setupAVSession()
                cameraView.previewLayer.session = cameraFeedSession
            }
            cameraFeedSession?.startRunning()
        } catch {
            AppError.display(error, inViewController: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewWillDisappear(animated)
    }
    
    private func createSelectedCheckerView() {
        let size: CGFloat = 80
        let initialLocation = CGPoint(x: 0, y: 0)
        
        floatingCheckerView = Checker(color: .white, location: initialLocation, size: size)
        floatingCheckerView?.setSelected(true)
        floatingCheckerView?.isHidden = true
        
        if let checkerView = floatingCheckerView {
            view.addSubview(checkerView)
        }
    }
    
    
    private func updateFloatingCheckerPosition(midpoint: CGPoint) {
        DispatchQueue.main.async {
            if let checkerView = self.floatingCheckerView {
                checkerView.center = self.view.convert(midpoint, from: self.cameraView)
            }
        }
    }
    
    
    func initializeCheckersGameFrom2DArray() {
        DispatchQueue.main.async {
            self.chessBoardView.deployCheckerOnBoard()
        }
        
    }
    
    private func calculateBoardCoordinates() {
        let chessBoardSize = chessBoardView.frame.size.width
        let squareSize = chessBoardSize / 8
        
        rowRanges.removeAll()
        columnRanges.removeAll()
        
        let topLeftCornerX = chessBoardView.center.x - (chessBoardSize / 2)
        let topLeftCornerY = chessBoardView.center.y - (chessBoardSize / 2)
        
        for i in 0..<8 {
            let start = topLeftCornerY + CGFloat(i) * squareSize // For rows
            let end = start + squareSize
            rowRanges.append((start, end))
            
            let columnStart = topLeftCornerX + CGFloat(i) * squareSize // For columns
            let columnEnd = columnStart + squareSize
            columnRanges.append((columnStart, columnEnd))
        }
        
    }
    
    func setupAVSession() throws {
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            throw AppError.captureSessionSetup(reason: "Could not find a front facing camera.")
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            throw AppError.captureSessionSetup(reason: "Could not create video device input.")
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        guard session.canAddInput(deviceInput) else {
            throw AppError.captureSessionSetup(reason: "Could not add video device input to the session")
        }
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            // Add a video data output.
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            throw AppError.captureSessionSetup(reason: "Could not add video data output to the session")
        }
        session.commitConfiguration()
        cameraFeedSession = session
    }
    
    private func findPosition(for point: CGPoint) -> (row: Int, column: Int)? {
        let rowIndex = rowRanges.firstIndex(where: { $0.start <= point.y && point.y < $0.end })
        let columnIndex = columnRanges.firstIndex(where: { $0.start <= point.x && point.x < $0.end })
        
        if let rowIndex = rowIndex, let columnIndex = columnIndex {
            return (row: rowIndex, column: columnIndex)
        } else {
            return nil
        }
    }
    
    func processPoints(thumbTip: CGPoint?, indexTip: CGPoint?) {
        guard let thumbPoint = thumbTip, let indexPoint = indexTip else {
            if Date().timeIntervalSince(lastObservationTimestamp) > 2 {
                gestureProcessor.reset()
            }
            cameraView.showPoints([], color: .clear)
            return
        }
        
        // Convert points from AVFoundation coordinates to UIKit coordinates.
        let previewLayer = cameraView.previewLayer
        let thumbPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: thumbPoint)
        let indexPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: indexPoint)
        
        let thumbPosition = findPosition(for: thumbPointConverted)
        let indexPosition = findPosition(for: indexPointConverted)
        
        
        gestureProcessor.processPointsPair((thumbPointConverted, indexPointConverted))
    }
    
    private func isWhiteCheckerAt(row: Int, column: Int) -> Bool {
        return Game.shared.isWhiteCheckerAt(row: row, col: column)
    }
    
    
    private func isMovableCheckerAt(row: Int, column: Int) -> Bool {
        let spot = Coordinate(row: row, col: column)
        let movableCheckers = Game.shared.findMovableCheckers()
        if movableCheckers.contains(spot) {
            return true
        }
        else {
            return false
        }
    }
    
    private func removeCheckerOnBoard(row: Int, column: Int) {
        Game.shared.removeCheckerAt(row: row, column: column)
        self.chessBoardView.deployCheckerOnBoard()
    }
    
    private func isPlacableCellAt(row: Int, column: Int) -> Bool {
        let spot = Coordinate(row: row, col: column)
        let possiblePlaces = Game.shared.possibleDropPoint()
        if possiblePlaces.contains(spot) {
            return true
        }
        else {
            return false
        }
    }
    
    
    private func placeCheckerOnBoard(row: Int, column: Int) {
        Game.shared.placeCheckerAt(row: row, column: column)
        self.chessBoardView.deployCheckerOnBoard()

    }
    
    private func handleGestureStateChange(state: HandGestureProcessor.State) {
        let pointsPair = gestureProcessor.lastProcessedPointsPair
        var tipsColor: UIColor
        switch state {
        case .possiblePinch, .possibleApart:
            evidenceBuffer.append(pointsPair)
            tipsColor = .orange
            isPinching = false
        case .pinched:
            evidenceBuffer.removeAll()
            tipsColor = .green
            isPinching = true
            if previousState == .possiblePinch {
                print("Previous State is possible pinched")
                if let thumbPosition = self.findPosition(for: pointsPair.thumbTip),
                   let indexPosition = self.findPosition(for: pointsPair.indexTip),
                   thumbPosition.row == indexPosition.row && thumbPosition.column == indexPosition.column {
                    print("Previous State is possible pinched AND fingers focusing on a cell")
                    if isMovableCheckerAt(row: thumbPosition.row, column: thumbPosition.column) {
                        print("[[[Is movable checker]]] + Previous State is possible pinched AND fingers focusing on a cell")
                        Game.shared.selected = Coordinate(row: thumbPosition.row, col: thumbPosition.column)
                        removeCheckerOnBoard(row: thumbPosition.row, column: thumbPosition.column)
                        isHolding = true
                        Game.shared.state = .choice
                        self.floatingCheckerView?.isHidden = false
                    }
                }
            }
            
            if let thumbPosition = self.findPosition(for: pointsPair.thumbTip),
               let indexPosition = self.findPosition(for: pointsPair.indexTip),
               thumbPosition.row == indexPosition.row && thumbPosition.column == indexPosition.column {
                if isPinching && isHolding {
                    let midpoint = CGPoint(x: (pointsPair.thumbTip.x + pointsPair.indexTip.x) / 2,
                                           y: (pointsPair.thumbTip.y + pointsPair.indexTip.y) / 2)
                    self.updateFloatingCheckerPosition(midpoint: midpoint)
                    
                }
            }
        case .apart, .unknown:
            if previousState == .possibleApart {
                print("Previous State is possible apart")
                if isHolding {
                    let droppedPoint = CGPoint(x: (pointsPair.thumbTip.x + pointsPair.indexTip.x) / 2,
                                               y: (pointsPair.thumbTip.y + pointsPair.indexTip.y) / 2)
                    if let droppedPosition = self.findPosition(for: droppedPoint) {
                        print("Previous State is possible apart AND droped on a cell")
                        if isPlacableCellAt(row: droppedPosition.row, column: droppedPosition.column) {
                            print("[[[Droppable Place]]]Previous State is possible apart AND droped on a cell")
                            placeCheckerOnBoard(row: droppedPosition.row, column: droppedPosition.column)
                            guard Game.shared.selected != nil else {
                                return
                            }
                            let start = Game.shared.selected
                            let end = Coordinate(row: droppedPosition.row, col: droppedPosition.column)
                            Game.shared.placedChecker(from: start!, to: end)
                            Game.shared.selected = nil
                            self.chessBoardView.deployCheckerOnBoard()
                        }
                        else{
                            guard (Game.shared.selected != nil) else {
                                return
                            }
                            placeCheckerOnBoard(row: Game.shared.selected!.row, column: Game.shared.selected!.col)
                        }
                        self.floatingCheckerView?.isHidden = true
                    }
                }

            }
            evidenceBuffer.removeAll()
            isPinching = false
            isHolding = false
            Game.shared.state = .hint
            tipsColor = .red
        }
        cameraView.showPoints([pointsPair.thumbTip, pointsPair.indexTip], color: tipsColor)
        previousState = state
    }
    
    @IBAction func handleGesture(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else {
            return
        }
        evidenceBuffer.removeAll()
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        var thumbTip: CGPoint?
        var indexTip: CGPoint?
        
        defer {
            DispatchQueue.main.sync {
                self.processPoints(thumbTip: thumbTip, indexTip: indexTip)
            }
        }
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([handPoseRequest])
            guard let observation = handPoseRequest.results?.first else {
                return
            }
            let thumbPoints = try observation.recognizedPoints(.thumb)
            let indexFingerPoints = try observation.recognizedPoints(.indexFinger)
            guard let thumbTipPoint = thumbPoints[.thumbTip], let indexTipPoint = indexFingerPoints[.indexTip] else {
                return
            }
            guard thumbTipPoint.confidence > 0.3 && indexTipPoint.confidence > 0.3 else {
                return
            }
            thumbTip = CGPoint(x: thumbTipPoint.location.x, y: 1 - thumbTipPoint.location.y)
            indexTip = CGPoint(x: indexTipPoint.location.x, y: 1 - indexTipPoint.location.y)
        } catch {
            cameraFeedSession?.stopRunning()
            let error = AppError.visionError(error: error)
            DispatchQueue.main.async {
                error.displayInViewController(self)
            }
        }
    }
}
