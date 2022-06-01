import BlockchainNamespace
import Foundation
import ToolKit

public class ErrorActionObserver: Session.Observer {

    unowned var app: AppProtocol
    var application: URLOpener

    public init(app: AppProtocol, application: URLOpener) {
        self.app = app
        self.application = application
    }

    lazy var launchURL = app.on(blockchain.ux.error.then.launch.url) { [app, application] event in
        let url = try event.context.decode(blockchain.ux.error.then.launch.url, as: URL.self)
        guard app.deepLinks.canProcess(url: url) else {
            return application.open(url)
        }
        app.post(
            event: blockchain.app.process.deep_link,
            context: [blockchain.app.process.deep_link.url: url]
        )
    }

    public func start() {
        launchURL.start()
    }

    public func stop() {
        launchURL.stop()
    }
}
