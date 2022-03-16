//
//  Network.swift
//  RocketReserver
//
//  Created by 東原　与生 on 2022/03/14.
//  Copyright © 2022 Apollo GraphQL. All rights reserved.
//

import Foundation

import Apollo
import ApolloWebSocket

class Network {
    static let shared = Network()
    
    private(set) lazy var apollo: ApolloClient = {
        let client = URLSessionClient()
        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)
        let provider = NetworkInterceptorProvider(client: client, store: store)
        let url = URL(string: "https://apollo-fullstack-tutorial.herokuapp.com/graphql")!
        let transport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                     endpointURL: url)

        let webSocket = WebSocket(
          url: URL(string: "wss://apollo-fullstack-tutorial.herokuapp.com/graphql")!,
          protocol: .graphql_ws
        )

        let webSocketTransport = WebSocketTransport(websocket: webSocket)

        let splitTransport = SplitNetworkTransport(
          uploadingNetworkTransport: transport,
          webSocketNetworkTransport: webSocketTransport
        )

        return ApolloClient(networkTransport: splitTransport, store: store)
    }()
}
