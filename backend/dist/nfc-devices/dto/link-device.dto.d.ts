export declare enum DeviceType {
    CARD = "CARD",
    WRISTBAND = "WRISTBAND",
    PHONE = "PHONE"
}
export declare class LinkDeviceDto {
    deviceUid: string;
    deviceType: DeviceType;
    label?: string;
}
