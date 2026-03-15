enum StartupStatus {
  pending,
  approved,
  rejected,
  suspended;

  String get displayName => switch (this) {
        StartupStatus.pending => 'Pending',
        StartupStatus.approved => 'Approved',
        StartupStatus.rejected => 'Rejected',
        StartupStatus.suspended => 'Suspended',
      };

  static StartupStatus fromString(String? value) => switch (value?.toLowerCase()) {
        'approved' => StartupStatus.approved,
        'rejected' => StartupStatus.rejected,
        'suspended' => StartupStatus.suspended,
        _ => StartupStatus.pending,
      };
}