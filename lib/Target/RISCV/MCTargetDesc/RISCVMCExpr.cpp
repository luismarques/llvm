//===-- RISCVMCExpr.cpp - RISCV specific MC expression classes ------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the implementation of the assembly expression modifiers
// accepted by the RISCV architecture (e.g. ":lo12:", ":gottprel_g1:", ...).
//
//===----------------------------------------------------------------------===//

#include "RISCV.h"
#include "RISCVMCExpr.h"
#include "RISCVFixupKinds.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSymbolELF.h"
#include "llvm/MC/MCValue.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

#define DEBUG_TYPE "riscvmcexpr"

const RISCVMCExpr *RISCVMCExpr::create(const MCExpr *Expr, VariantKind Kind,
                                       MCContext &Ctx) {
  return new (Ctx) RISCVMCExpr(Expr, Kind);
}

void RISCVMCExpr::printImpl(raw_ostream &OS, const MCAsmInfo *MAI) const {
  bool HasVariant =
      ((getKind() != VK_RISCV_None) && (getKind() != VK_RISCV_CALL));
  if (HasVariant)
    OS << '%' << getVariantKindName(getKind()) << '(';
  Expr->print(OS, MAI);
  if (HasVariant)
    OS << ')';
}

const MCFixup *RISCVMCExpr::getPCRelHiFixup() const {
  MCValue AUIPCLoc;
  if (!getSubExpr()->evaluateAsRelocatable(AUIPCLoc, nullptr, nullptr))
    return nullptr;

  const MCSymbolRefExpr *AUIPCSRE = AUIPCLoc.getSymA();
  if (!AUIPCSRE)
    return nullptr;

  const MCSymbol *AUIPCSymbol = &AUIPCSRE->getSymbol();
  const auto *DF = dyn_cast_or_null<MCDataFragment>(AUIPCSymbol->getFragment());

  if (!DF)
    return nullptr;

  uint64_t Offset = AUIPCSymbol->getOffset();
  if (DF->getContents().size() == Offset) {
    DF = dyn_cast_or_null<MCDataFragment>(DF->getNextNode());
    if (!DF)
      return nullptr;
    Offset = 0;
  }

  for (const MCFixup &F : DF->getFixups()) {
    if (F.getOffset() != Offset)
      continue;

    switch ((unsigned)F.getKind()) {
    default:
      continue;
    case RISCV::fixup_riscv_got_hi20:
    case RISCV::fixup_riscv_pcrel_hi20:
      return &F;
    }
  }

  return nullptr;
}

bool RISCVMCExpr::evaluateAsRelocatableImpl(MCValue &Res,
                                            const MCAsmLayout *Layout,
                                            const MCFixup *Fixup) const {
  if (!getSubExpr()->evaluateAsRelocatable(Res, Layout, Fixup))
    return false;

  // Some custom fixup types are not valid with symbol difference expressions
  if (Res.getSymA() && Res.getSymB()) {
    switch (getKind()) {
    default:
      return true;
    case VK_RISCV_LO:
    case VK_RISCV_HI:
    case VK_RISCV_PCREL_LO:
    case VK_RISCV_PCREL_HI:
    case VK_RISCV_GOT_HI:
      return false;
    }
  }

  return true;
}

void RISCVMCExpr::visitUsedExpr(MCStreamer &Streamer) const {
  Streamer.visitUsedExpr(*getSubExpr());
}

RISCVMCExpr::VariantKind RISCVMCExpr::getVariantKindForName(StringRef name) {
  return StringSwitch<RISCVMCExpr::VariantKind>(name)
      .Case("lo", VK_RISCV_LO)
      .Case("hi", VK_RISCV_HI)
      .Case("pcrel_lo", VK_RISCV_PCREL_LO)
      .Case("pcrel_hi", VK_RISCV_PCREL_HI)
      .Case("got_pcrel_hi", VK_RISCV_GOT_HI)
      .Default(VK_RISCV_Invalid);
}

StringRef RISCVMCExpr::getVariantKindName(VariantKind Kind) {
  switch (Kind) {
  default:
    llvm_unreachable("Invalid ELF symbol kind");
  case VK_RISCV_LO:
    return "lo";
  case VK_RISCV_HI:
    return "hi";
  case VK_RISCV_PCREL_LO:
    return "pcrel_lo";
  case VK_RISCV_PCREL_HI:
    return "pcrel_hi";
  case VK_RISCV_GOT_HI:
    return "got_pcrel_hi";
  }
}

bool RISCVMCExpr::evaluateAsConstant(int64_t &Res) const {
  MCValue Value;

  if (Kind == VK_RISCV_PCREL_HI || Kind == VK_RISCV_PCREL_LO ||
      Kind == VK_RISCV_GOT_HI || Kind == VK_RISCV_CALL)
    return false;

  if (!getSubExpr()->evaluateAsRelocatable(Value, nullptr, nullptr))
    return false;

  if (!Value.isAbsolute())
    return false;

  Res = evaluateAsInt64(Value.getConstant());
  return true;
}

int64_t RISCVMCExpr::evaluateAsInt64(int64_t Value) const {
  switch (Kind) {
  default:
    llvm_unreachable("Invalid kind");
  case VK_RISCV_LO:
    return SignExtend64<12>(Value);
  case VK_RISCV_HI:
    // Add 1 if bit 11 is 1, to compensate for low 12 bits being negative.
    return ((Value + 0x800) >> 12) & 0xfffff;
  }
}
