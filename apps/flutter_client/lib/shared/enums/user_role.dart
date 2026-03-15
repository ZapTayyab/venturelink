enum UserRole {
  entrepreneur,
  investor,
  admin,
  pending;

  String get displayName => switch (this) {
        UserRole.entrepreneur => 'Founder',
        UserRole.investor => 'Investor',
        UserRole.admin => 'Admin',
        UserRole.pending => 'Pending',
      };

  static UserRole fromString(String? value) => switch (value?.toLowerCase()) {
        'entrepreneur' => UserRole.entrepreneur,
        'investor' => UserRole.investor,
        'admin' => UserRole.admin,
        _ => UserRole.pending,
      };
}