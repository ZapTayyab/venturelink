enum RoundStatus {
  draft,
  open,
  closed,
  cancelled;

  String get displayName => switch (this) {
        RoundStatus.draft => 'Draft',
        RoundStatus.open => 'Open',
        RoundStatus.closed => 'Closed',
        RoundStatus.cancelled => 'Cancelled',
      };

  static RoundStatus fromString(String? value) => switch (value?.toLowerCase()) {
        'open' => RoundStatus.open,
        'closed' => RoundStatus.closed,
        'cancelled' => RoundStatus.cancelled,
        _ => RoundStatus.draft,
      };
}