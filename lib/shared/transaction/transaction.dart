import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:mtm/shared/token/token.dart';

enum TransactionType { reward, transfer, withdraw, stake, unstake }
enum TransactionStatus { pending, processing, completed, failed, cancelled }

class MTMTransaction extends Equatable {
  final String id;
  final String userId;
  final TransactionType type;
  final TransactionStatus status;
  final SPLToken token;
  final int amount; // in smallest units
  final String? fromAddress;
  final String? toAddress;
  final String? signature;
  final String? blockHash;
  final int? blockHeight;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? failureReason;
  final Map<String, dynamic> metadata;
  final double? fee; // in SOL

  const MTMTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.token,
    required this.amount,
    this.fromAddress,
    this.toAddress,
    this.signature,
    this.blockHash,
    this.blockHeight,
    required this.createdAt,
    this.completedAt,
    this.failureReason,
    required this.metadata,
    this.fee,
  });

  factory MTMTransaction.fromFirestore(DocumentSnapshot doc, SPLToken token) {
    final data = doc.data() as Map<String, dynamic>;
    
    return MTMTransaction(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => TransactionType.reward,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => TransactionStatus.pending,
      ),
      token: token,
      amount: data['amount'] ?? 0,
      fromAddress: data['fromAddress'],
      toAddress: data['toAddress'],
      signature: data['signature'],
      blockHash: data['blockHash'],
      blockHeight: data['blockHeight'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      failureReason: data['failureReason'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      fee: data['fee']?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'tokenMint': token.mintAddress,
      'amount': amount,
      'fromAddress': fromAddress,
      'toAddress': toAddress,
      'signature': signature,
      'blockHash': blockHash,
      'blockHeight': blockHeight,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'failureReason': failureReason,
      'metadata': metadata,
      'fee': fee,
    };
  }

  MTMTransaction copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    TransactionStatus? status,
    SPLToken? token,
    int? amount,
    String? fromAddress,
    String? toAddress,
    String? signature,
    String? blockHash,
    int? blockHeight,
    DateTime? createdAt,
    DateTime? completedAt,
    String? failureReason,
    Map<String, dynamic>? metadata,
    double? fee,
  }) {
    return MTMTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      token: token ?? this.token,
      amount: amount ?? this.amount,
      fromAddress: fromAddress ?? this.fromAddress,
      toAddress: toAddress ?? this.toAddress,
      signature: signature ?? this.signature,
      blockHash: blockHash ?? this.blockHash,
      blockHeight: blockHeight ?? this.blockHeight,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      failureReason: failureReason ?? this.failureReason,
      metadata: metadata ?? this.metadata,
      fee: fee ?? this.fee,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        status,
        token,
        amount,
        fromAddress,
        toAddress,
        signature,
        blockHash,
        blockHeight,
        createdAt,
        completedAt,
        failureReason,
        metadata,
        fee,
      ];

  // Helper getters
  String get formattedAmount => token.formatAmount(amount);
  double get amountAsDouble => token.fromSmallestUnit(amount);
  
  bool get isPending => status == TransactionStatus.pending;
  bool get isProcessing => status == TransactionStatus.processing;
  bool get isCompleted => status == TransactionStatus.completed;
  bool get isFailed => status == TransactionStatus.failed;
  bool get isCancelled => status == TransactionStatus.cancelled;
  
  bool get isReward => type == TransactionType.reward;
  bool get isTransfer => type == TransactionType.transfer;
  bool get isWithdraw => type == TransactionType.withdraw;
  bool get isStake => type == TransactionType.stake;
  bool get isUnstake => type == TransactionType.unstake;

  String get typeDisplayName {
    switch (type) {
      case TransactionType.reward:
        return 'Reward';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.withdraw:
        return 'Withdraw';
      case TransactionType.stake:
        return 'Stake';
      case TransactionType.unstake:
        return 'Unstake';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.processing:
        return 'Processing';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

  String? get explorerUrl {
    if (signature == null) return null;
    return 'https://explorer.solana.com/tx/$signature';
  }

  String? get formattedFee {
    if (fee == null) return null;
    return '${fee!.toStringAsFixed(6)} SOL';
  }

  Duration? get processingTime {
    if (completedAt == null) return null;
    return completedAt!.difference(createdAt);
  }

  // Get transaction description based on type and metadata
  String get description {
    switch (type) {
      case TransactionType.reward:
        final reason = metadata['reason'] ?? 'listening';
        final trackTitle = metadata['trackTitle'] ?? 'Unknown Track';
        return 'Reward for $reason: $trackTitle';
      case TransactionType.transfer:
        return 'Transfer to ${_formatAddress(toAddress)}';
      case TransactionType.withdraw:
        return 'Withdraw to external wallet';
      case TransactionType.stake:
        return 'Stake tokens for rewards';
      case TransactionType.unstake:
        return 'Unstake tokens';
    }
  }

  String _formatAddress(String? address) {
    if (address == null || address.length <= 16) return address ?? 'Unknown';
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}

class TransactionBatch extends Equatable {
  final String id;
  final String userId;
  final List<MTMTransaction> transactions;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? failureReason;
  final Map<String, dynamic> metadata;

  const TransactionBatch({
    required this.id,
    required this.userId,
    required this.transactions,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.failureReason,
    required this.metadata,
  });

  factory TransactionBatch.fromFirestore(
    DocumentSnapshot doc,
    List<MTMTransaction> transactions,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TransactionBatch(
      id: doc.id,
      userId: data['userId'] ?? '',
      transactions: transactions,
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => TransactionStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      failureReason: data['failureReason'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'transactionIds': transactions.map((t) => t.id).toList(),
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'failureReason': failureReason,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        transactions,
        status,
        createdAt,
        completedAt,
        failureReason,
        metadata,
      ];

  // Helper getters
  int get totalAmount => transactions.fold(0, (sum, tx) => sum + tx.amount);
  int get completedTransactions => transactions.where((tx) => tx.isCompleted).length;
  int get failedTransactions => transactions.where((tx) => tx.isFailed).length;
  
  bool get isCompleted => status == TransactionStatus.completed;
  bool get isFailed => status == TransactionStatus.failed;
  bool get isProcessing => status == TransactionStatus.processing;
  
  double get progressPercentage {
    if (transactions.isEmpty) return 0.0;
    return (completedTransactions / transactions.length) * 100;
  }
}

// Factory methods for creating specific transaction types
class TransactionFactory {
  static MTMTransaction createRewardTransaction({
    required String userId,
    required String walletAddress,
    required int amount,
    required String reason,
    String? trackId,
    String? artistId,
    String? trackTitle,
    SPLToken token = SPLToken.mtmToken,
  }) {
    return MTMTransaction(
      id: '', // Will be set by Firestore
      userId: userId,
      type: TransactionType.reward,
      status: TransactionStatus.pending,
      token: token,
      amount: amount,
      toAddress: walletAddress,
      createdAt: DateTime.now(),
      metadata: {
        'reason': reason,
        'trackId': trackId,
        'artistId': artistId,
        'trackTitle': trackTitle,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static MTMTransaction createTransferTransaction({
    required String userId,
    required String fromAddress,
    required String toAddress,
    required int amount,
    SPLToken token = SPLToken.mtmToken,
    Map<String, dynamic>? additionalMetadata,
  }) {
    return MTMTransaction(
      id: '', // Will be set by Firestore
      userId: userId,
      type: TransactionType.transfer,
      status: TransactionStatus.pending,
      token: token,
      amount: amount,
      fromAddress: fromAddress,
      toAddress: toAddress,
      createdAt: DateTime.now(),
      metadata: {
        'transferType': 'user_to_user',
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalMetadata,
      },
    );
  }

  static MTMTransaction createWithdrawTransaction({
    required String userId,
    required String fromAddress,
    required String toAddress,
    required int amount,
    SPLToken token = SPLToken.mtmToken,
  }) {
    return MTMTransaction(
      id: '', // Will be set by Firestore
      userId: userId,
      type: TransactionType.withdraw,
      status: TransactionStatus.pending,
      token: token,
      amount: amount,
      fromAddress: fromAddress,
      toAddress: toAddress,
      createdAt: DateTime.now(),
      metadata: {
        'withdrawType': 'external_wallet',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}