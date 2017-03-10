export class Notifier {
  private clients = [];

  // Register a function to call on notification of changes
  addClient(client): void {
    this.clients.push(client);
  }

  notify(): void {
    this.clients.forEach((client) => {
      client();
    });
  }
}
