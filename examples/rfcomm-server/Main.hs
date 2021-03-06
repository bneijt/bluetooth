module Main where

import Control.Exception

import Data.Set

import Network.Bluetooth
import Network.Socket

import Utils

main :: IO ()
main = withSocketsDo $ do
    let backlog  = 1
        proto    = RFCOMM
        uuid     = serviceClassToUUID SerialPort -- TODO: Change to better UUID
        settings = defaultSDPInfo {
            sdpServiceName    = Just "Roto-Rooter Data Router"
          , sdpProviderName   = Just "Roto-Rooter"
          , sdpDescription    = Just "An experimental plumbing router"
          , sdpServiceClasses = singleton SerialPort
          , sdpProfiles       = singleton SerialPort
        }
        messLen  = 4096
    handshakeSock <- commentate "Calling socket" $ btSocket proto
    btPort <- commentate "Calling bind" $ btBindAnyPort handshakeSock anyAddr
    
    putStrLn $ "Bound on port " ++ show btPort
    (btAddr, _) <- btSocketInfo handshakeSock
    print btAddr
    
    commentate ("Calling listen with backlog " ++ show backlog) $
      btListen handshakeSock backlog
    service <- commentate ("Registering SDP service " ++ show uuid) $
      registerSDPService uuid settings proto btPort
    (connSock, connAddr) <- commentate "Calling accept" $
      btAccept handshakeSock
      
    putStrLn $ "Established connection with address " ++ show connAddr
    
    let conversation :: IO ()
        conversation = do
            message <- commentate ("\nCalling recv with " ++ show messLen ++ " bytes") $
              recv connSock messLen
            
            putStrLn $ "Received message! [" ++ message ++ "]"
            let response = reverse message
            
            respBytes <- commentate ("Calling send with response [" ++ response ++ "]") $
              send connSock response
            
            putStrLn $ "Sent response! " ++ show respBytes ++ " bytes."
            
            conversation
    
        cleanup :: IO ()
        cleanup = do
            close connSock
            close handshakeSock
            closeSDPService service
    
    conversation `onException` cleanup