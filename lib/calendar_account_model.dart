class CalendarAccount {
  final String calenderId;
  final String accountName;
  final String accountType;
  final AndroidAccountParams? androidAccountParams;
  final IosAccountParams? iosAccountParams;

  CalendarAccount(this.calenderId, this.accountName, this.accountType,
      {this.androidAccountParams, this.iosAccountParams});
}

class AndroidAccountParams {
  final bool isPrimary;
  final String displayName;
  final String ownerAccount;
  final String name;

  AndroidAccountParams(
      this.isPrimary, this.displayName, this.ownerAccount, this.name);
}

class IosAccountParams {
  final String sourceId;
  final String sourceType;
  final String sourceTitle;

  IosAccountParams(this.sourceId, this.sourceType, this.sourceTitle);
}
