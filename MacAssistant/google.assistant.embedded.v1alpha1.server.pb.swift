/*
 * DO NOT EDIT.
 *
 * Generated by the protocol buffer compiler.
 * Source: google/assistant/embedded/v1alpha1/embedded_assistant.proto
 *
 */

/*
 *
 * Copyright 2017, Google Inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the
 * distribution.
 *     * Neither the name of Google Inc. nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

import Foundation
import Dispatch
import gRPC

/// Type for errors thrown from generated server code.
public enum Google_Assistant_Embedded_V1Alpha1_EmbeddedAssistantServerError : Error {
  case endOfStream
}

/// To build a server, implement a class that conforms to this protocol.
public protocol Google_Assistant_Embedded_V1Alpha1_EmbeddedAssistantProvider {
  func converse(session : Google_Assistant_Embedded_V1Alpha1_EmbeddedAssistantConverseSession) throws
}

/// Common properties available in each service session.
public class Google_Assistant_Embedded_V1Alpha1_EmbeddedAssistantSession {
  fileprivate var handler : gRPC.Handler
  public var requestMetadata : Metadata { return handler.requestMetadata }

  public var statusCode : Int = 0
  public var statusMessage : String = "OK"
  public var initialMetadata : Metadata = Metadata()
  public var trailingMetadata : Metadata = Metadata()

  fileprivate init(handler:gRPC.Handler) {
    self.handler = handler
  }
}

// Converse (Bidirectional Streaming)
public class Google_Assistant_Embedded_V1Alpha1_EmbeddedAssistantConverseSession : Google_Assistant_Embedded_V1Alpha1_EmbeddedAssistantSession {
  private var provider : Google_Assistant_Embedded_V1Alpha1_EmbeddedAssistantProvider

  /// Create a session.
  fileprivate init(handler:gRPC.Handler, provider: Google_Assistant_Embedded_V1Alpha1_EmbeddedAssistantProvider) {
    self.provider = provider
    super.init(handler:handler)
  }

  /// Receive a message. Blocks until a message is received or the client closes the connection.
  public func receive() throws -> Google_Assistant_Embedded_V1alpha1_ConverseRequest {
    let sem = DispatchSemaphore(value: 0)
    var requestMessage : Google_Assistant_Embedded_V1alpha1_ConverseRequest?
    try self.handler.receiveMessage() {(requestData) in
      if let requestData = requestData {
        do {
          requestMessage = try Google_Assistant_Embedded_V1alpha1_ConverseRequest(serializedData:requestData)
        } catch (let error) {
          print("error \(error)")
        }
      }
      sem.signal()
    }
    _ = sem.wait(timeout: DispatchTime.distantFuture)
    if let requestMessage = requestMessage {
      return requestMessage
    } else {
      throw Google_Assistant_Embedded_V1Alpha1_EmbeddedAssistantServerError.endOfStream
    }
  }

  /// Send a message. Nonblocking.
  public func send(_ response: Google_Assistant_Embedded_V1alpha1_ConverseResponse) throws {
    try handler.sendResponse(message:response.serializedData()) {}
  }

  /// Close a connection. Blocks until the connection is closed.
  public func close() throws {
    let sem = DispatchSemaphore(value: 0)
    try self.handler.sendStatus(statusCode:self.statusCode,
                                statusMessage:self.statusMessage,
                                trailingMetadata:self.trailingMetadata) {
                                  sem.signal()
    }
    _ = sem.wait(timeout: DispatchTime.distantFuture)
  }

  /// Run the session. Internal.
  fileprivate func run(queue:DispatchQueue) throws {
    try self.handler.sendMetadata(initialMetadata:initialMetadata) {
      queue.async {
        do {
          try self.provider.converse(session:self)
        } catch (let error) {
          print("error \(error)")
        }
      }
    }
  }
}


/// Main server for generated service
public class Google_Assistant_Embedded_V1Alpha1_EmbeddedAssistantServer {
  private var address: String
  private var server: gRPC.Server
  private var provider: Google_Assistant_Embedded_V1Alpha1_EmbeddedAssistantProvider?

  /// Create a server that accepts insecure connections.
  public init(address:String,
              provider:Google_Assistant_Embedded_V1Alpha1_EmbeddedAssistantProvider) {
    gRPC.initialize()
    self.address = address
    self.provider = provider
    self.server = gRPC.Server(address:address)
  }

  /// Create a server that accepts secure connections.
  public init?(address:String,
               certificateURL:URL,
               keyURL:URL,
               provider:Google_Assistant_Embedded_V1Alpha1_EmbeddedAssistantProvider) {
    gRPC.initialize()
    self.address = address
    self.provider = provider
    guard
      let certificate = try? String(contentsOf: certificateURL, encoding: .utf8),
      let key = try? String(contentsOf: keyURL, encoding: .utf8)
      else {
        return nil
    }
    self.server = gRPC.Server(address:address, key:key, certs:certificate)
  }

  /// Start the server.
  public func start(queue:DispatchQueue = DispatchQueue.global()) {
    guard let provider = self.provider else {
      assert(false) // the server requires a provider
      return
    }
    server.run {(handler) in
      print("Server received request to " + handler.host
        + " calling " + handler.method
        + " from " + handler.caller
        + " with " + String(describing:handler.requestMetadata) )

      do {
        switch handler.method {
        case "/google.assistant.embedded.v1alpha1.EmbeddedAssistant/Converse":
          try Google_Assistant_Embedded_V1Alpha1_EmbeddedAssistantConverseSession(handler:handler, provider:provider).run(queue:queue)
        default:
          break // handle unknown requests
        }
      } catch (let error) {
        print("Server error: \(error)")
      }
    }
  }
}
