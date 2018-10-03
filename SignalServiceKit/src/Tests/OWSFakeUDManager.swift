//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

import Foundation
import SignalMetadataKit

#if DEBUG

@objc
public class OWSFakeUDManager: NSObject, OWSUDManager {

    @objc public func setup() {}

    // MARK: - Recipient state

    private var udRecipientSet = Set<String>()

    @objc
    public func isUDRecipientId(_ recipientId: String) -> Bool {
        return udRecipientSet.contains(recipientId)
    }

    @objc
    public func addUDRecipientId(_ recipientId: String) {
        udRecipientSet.insert(recipientId)
    }

    @objc
    public func removeUDRecipientId(_ recipientId: String) {
        udRecipientSet.remove(recipientId)
    }

    // Returns the UD access key for a given recipient if they are
    // a UD recipient and we have a valid profile key for them.
    @objc
    public func udAccessKeyForRecipient(_ recipientId: String) -> SMKUDAccessKey? {
        guard isUDRecipientId(recipientId) else {
            return nil
        }
        guard let profileKey = Randomness.generateRandomBytes(Int32(kAES256_KeyByteLength)) else {
            // Mark as "not a UD recipient".
            removeUDRecipientId(recipientId)
            return nil
        }
        do {
            let udAccessKey = try SMKUDAccessKey(profileKey: profileKey)
            return udAccessKey
        } catch {
            Logger.error("Could not determine udAccessKey: \(error)")
            removeUDRecipientId(recipientId)
            return nil
        }
    }

    // MARK: - Server Certificate

    // Tests can control the behavior of this mock by setting this property.
    @objc public var nextSenderCertificate: Data?

    @objc public func ensureSenderCertificateObjC(success:@escaping (Data) -> Void,
                                                  failure:@escaping (Error) -> Void) {
        guard let certificateData = nextSenderCertificate else {
            failure(OWSUDError.assertionError(description: "No mock server certificate data"))
            return
        }
        success(certificateData)
    }

    // MARK: - Unrestricted Access

    private var _shouldAllowUnrestrictedAccess = false

    @objc
    public func shouldAllowUnrestrictedAccess() -> Bool {
        return _shouldAllowUnrestrictedAccess
    }

    @objc
    public func setShouldAllowUnrestrictedAccess(_ value: Bool) {
        _shouldAllowUnrestrictedAccess = value
    }
}

#endif
