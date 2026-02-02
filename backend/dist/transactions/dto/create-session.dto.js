"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.TransactionSessionResponse = exports.CreateTransactionSessionDto = void 0;
const class_validator_1 = require("class-validator");
class CreateTransactionSessionDto {
    amount;
    description;
    merchantReference;
}
exports.CreateTransactionSessionDto = CreateTransactionSessionDto;
__decorate([
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0.01),
    (0, class_validator_1.Max)(1000000),
    __metadata("design:type", Number)
], CreateTransactionSessionDto.prototype, "amount", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateTransactionSessionDto.prototype, "description", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateTransactionSessionDto.prototype, "merchantReference", void 0);
class TransactionSessionResponse {
    sessionId;
    amount;
    status;
    expiresAt;
    receiverWalletId;
    createdAt;
}
exports.TransactionSessionResponse = TransactionSessionResponse;
//# sourceMappingURL=create-session.dto.js.map