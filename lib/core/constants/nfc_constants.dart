/// NFC-specific constants for HCE and Reader Mode
class NfcConstants {
  // Custom AID (Application Identifier) - 7 bytes proprietary range
  static const String customAid = 'F0010203040506';
  static const List<int> customAidBytes = [0xF0, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06];
  
  // APDU Commands
  static const int selectAidCommand = 0xA4;
  static const int getPaymentTokenCommand = 0xC0;
  
  // APDU Response Codes
  static const int successResponse = 0x9000;
  static const int errorResponse = 0x6F00;
  static const int insufficientBalanceResponse = 0x6985;
  static const int authenticationRequiredResponse = 0x6982;
  
  // Method Channel Name
  static const String methodChannelName = 'com.graduation.nfc_wallet/nfc';
  
  // Method Names
  static const String methodStartReaderMode = 'startReaderMode';
  static const String methodStopReaderMode = 'stopReaderMode';
  static const String methodEnableHce = 'enableHCE';
  static const String methodDisableHce = 'disableHCE';
  static const String methodGenerateToken = 'generateNFCToken';
  static const String methodCheckNfcAvailability = 'checkNFCAvailability';
  
  // Event Channel for NFC callbacks
  static const String eventChannelName = 'com.graduation.nfc_wallet/nfc_events';
  
  // Token validity (2 minutes)
  static const Duration tokenValidity = Duration(minutes: 2);
  
  // Security
  static const int nonceLength = 32; // 32 bytes = 256 bits
  static const String encryptionAlgorithm = 'AES/GCM/NoPadding';
  static const int gcmTagLength = 128; // bits
}
