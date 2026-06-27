# Rype Phase 2 Portfolio Intelligence

## Updated Folder Structure

```text
rype-backend/src/imports/
  parsers/
    import-parser.types.ts
    import-parser.utils.ts
    table-import.parser.ts
    cas-pdf.parser.ts
    broker-pdf.parser.ts
    screenshot-ocr.parser.ts
  portfolio-merge.service.ts
  imports.controller.ts
  imports.service.ts
  schemas/
    portfolio-import.schema.ts
    import-transaction.schema.ts

rype-backend/src/portfolio-intelligence/
  dto/
    what-if-sell-amount.dto.ts
  schemas/
    portfolio-insight.schema.ts
  portfolio-intelligence.controller.ts
  portfolio-intelligence.service.ts
  portfolio-intelligence.module.ts
```

## API Changes

Existing import upload now supports more file families through the same endpoint:

```text
POST /imports/upload
GET /imports/history
GET /imports/:id
DELETE /imports/:id
```

Supported upload inputs:

```text
CSV, XLSX, PDF, PNG, JPG, JPEG, WEBP
```

New intelligence endpoints:

```text
GET  /portfolio-intelligence/insights
GET  /portfolio-intelligence/redemption
POST /portfolio-intelligence/what-if/sell-amount
GET  /portfolio-intelligence/alerts
GET  /portfolio-intelligence/metrics
GET  /portfolio-intelligence/future-architecture
```

## Database Changes

`PortfolioImport` now accepts advanced import types:

```text
CSV, XLSX, CAS_PDF, BROKER_CSV, BROKER_XLSX, BROKER_PDF, SCREENSHOT
```

`ImportTransaction` now stores:

```text
importId, userId, symbol, assetName, assetType, quantity, buyPrice,
buyDate, sourceFile, sourceType, folioNumber, investedAmount
```

New `PortfolioInsight` schema stores generated intelligence snapshots:

```text
userId, insights, createdAt, updatedAt
```

## AI Service Architecture

Phase 2 uses a deterministic AI insights engine first, with model integration prepared behind the service boundary:

```text
PortfolioIntelligenceService
  - portfolio health score
  - risk score
  - concentration risk
  - diversification score
  - tax optimization suggestions
  - redemption recommendations
  - what-if sell amount simulation
  - AI-style alert generation
```

Future LLM integration can be added inside `PortfolioIntelligenceService` without changing controllers or client contracts.

## Import Architecture

All imports normalize into the same row contract before portfolio merge:

```text
NormalizedImportRow
  date
  symbol
  assetName
  assetType
  quantity
  price
  investedAmount
  folioNumber
  sourceType
```

Parser modules:

```text
TableImportParser       CSV/XLSX broker and generic statements
CasPdfParser            CAMS/KFintech CAS PDFs
BrokerPdfParser         Zerodha/Groww/Angel One/Upstox PDFs
ScreenshotOcrParser     portfolio and holdings screenshots
```

## Deployment Guide

Install backend dependencies:

```powershell
cd "D:\study\Project\rype - Copy\rype-backend"
npm install
```

Required backend packages added in Phase 2:

```text
pdf-parse
tesseract.js
```

Validate backend:

```powershell
npm run build
npx jest src\imports --runInBand
```

Run backend:

```powershell
npm run start:dev
```

Environment variables remain the same:

```text
MONGODB_URI
JWT_SECRET
```

## Future Architecture Prepared

```text
Real Broker API Sync
  broker auth adapters, sync jobs, sync audit log

CAS Auto Email Import
  mailbox ingestion, CAS attachment parser, dedupe engine

Wealth Tracking
  net-worth ledger, external assets, liabilities

Family Portfolio Management
  family groups, member permissions, consolidated view
```
