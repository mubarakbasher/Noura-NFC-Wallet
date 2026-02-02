"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.NfcDevicesModule = void 0;
const common_1 = require("@nestjs/common");
const nfc_devices_service_1 = require("./nfc-devices.service");
const nfc_devices_controller_1 = require("./nfc-devices.controller");
let NfcDevicesModule = class NfcDevicesModule {
};
exports.NfcDevicesModule = NfcDevicesModule;
exports.NfcDevicesModule = NfcDevicesModule = __decorate([
    (0, common_1.Module)({
        controllers: [nfc_devices_controller_1.NfcDevicesController],
        providers: [nfc_devices_service_1.NfcDevicesService],
        exports: [nfc_devices_service_1.NfcDevicesService],
    })
], NfcDevicesModule);
//# sourceMappingURL=nfc-devices.module.js.map