class EventsConstants {
  static const chainChanged = 'chainChanged';
  static const accountsChanged = 'accountsChanged';
  static const requiredEvents = [
    chainChanged,
    accountsChanged,
  ];
  static const optionalEvents = [
    'message',
    'disconnect',
    'connect',
  ];
  static const allEvents = [...requiredEvents, ...optionalEvents];
}
