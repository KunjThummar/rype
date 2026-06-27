import 'dart:io';

import 'package:dio/dio.dart';

import 'api_service.dart';
import 'storage_service.dart';

class ImportSummary {
  ImportSummary({
    required this.data,
  });

  final Map<String, dynamic> data;

  List<String> get importedSymbols {
    final value = data['importedSymbols'];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return [];
  }

  List<ImportRowFailure> get failedRows {
    final value = data['failedRows'];
    if (value is List) {
      return value
          .whereType<Map>()
          .map(
            (item) => ImportRowFailure.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }
    return [];
  }

  String? get error => data['error']?.toString();
}

class ImportRowFailure {
  ImportRowFailure({
    required this.rowNumber,
    required this.reason,
  });

  final int rowNumber;
  final String reason;

  factory ImportRowFailure.fromJson(Map<String, dynamic> json) {
    return ImportRowFailure(
      rowNumber: (json['rowNumber'] as num?)?.toInt() ?? 0,
      reason: json['reason']?.toString() ?? 'Invalid row',
    );
  }
}

class PortfolioImportRecord {
  PortfolioImportRecord({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.uploadedAt,
    required this.status,
    required this.totalRecords,
    required this.successRecords,
    required this.failedRecords,
    required this.importSummary,
  });

  final String id;
  final String fileName;
  final String fileType;
  final DateTime uploadedAt;
  final String status;
  final int totalRecords;
  final int successRecords;
  final int failedRecords;
  final ImportSummary importSummary;

  factory PortfolioImportRecord.fromJson(Map<String, dynamic> json) {
    return PortfolioImportRecord(
      id: json['_id']?.toString() ?? '',
      fileName: json['fileName']?.toString() ?? '',
      fileType: json['fileType']?.toString() ?? '',
      uploadedAt: DateTime.tryParse(json['uploadedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      status: json['status']?.toString() ?? 'PENDING',
      totalRecords: (json['totalRecords'] as num?)?.toInt() ?? 0,
      successRecords: (json['successRecords'] as num?)?.toInt() ?? 0,
      failedRecords: (json['failedRecords'] as num?)?.toInt() ?? 0,
      importSummary: ImportSummary(
        data: Map<String, dynamic>.from(json['importSummary'] as Map? ?? {}),
      ),
    );
  }
}

class ImportTransactionRecord {
  ImportTransactionRecord({
    required this.symbol,
    required this.assetType,
    required this.quantity,
    required this.buyPrice,
    required this.buyDate,
    required this.sourceFile,
  });

  final String symbol;
  final String assetType;
  final double quantity;
  final double buyPrice;
  final DateTime buyDate;
  final String sourceFile;

  factory ImportTransactionRecord.fromJson(Map<String, dynamic> json) {
    return ImportTransactionRecord(
      symbol: json['symbol']?.toString() ?? '',
      assetType: json['assetType']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      buyPrice: (json['buyPrice'] as num?)?.toDouble() ?? 0.0,
      buyDate: DateTime.tryParse(json['buyDate']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      sourceFile: json['sourceFile']?.toString() ?? '',
    );
  }
}

class ImportDetail {
  ImportDetail({
    required this.importRecord,
    required this.transactions,
  });

  final PortfolioImportRecord importRecord;
  final List<ImportTransactionRecord> transactions;
}

class ImportService {
  static Future<Options> _authOptions() async {
    final token = await StorageService.getToken();
    return Options(
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<PortfolioImportRecord> uploadFile(
    File file, {
    ProgressCallback? onSendProgress,
  }) async {
    final token = await StorageService.getToken();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      ),
    });

    final response = await ApiService.dio.post(
      '/imports/upload',
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        contentType: Headers.multipartFormDataContentType,
      ),
      onSendProgress: onSendProgress,
    );

    return PortfolioImportRecord.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  static Future<List<PortfolioImportRecord>> getHistory() async {
    final response = await ApiService.dio.get(
      '/imports/history',
      options: await _authOptions(),
    );

    return (response.data as List<dynamic>)
        .whereType<Map>()
        .map(
          (item) => PortfolioImportRecord.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static Future<ImportDetail> getImport(String id) async {
    final response = await ApiService.dio.get(
      '/imports/$id',
      options: await _authOptions(),
    );

    final data = Map<String, dynamic>.from(response.data as Map);
    return ImportDetail(
      importRecord: PortfolioImportRecord.fromJson(
        Map<String, dynamic>.from(data['import'] as Map),
      ),
      transactions: (data['transactions'] as List<dynamic>)
          .whereType<Map>()
          .map(
            (item) => ImportTransactionRecord.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }

  static Future<void> deleteImport(String id) async {
    await ApiService.dio.delete(
      '/imports/$id',
      options: await _authOptions(),
    );
  }
}
