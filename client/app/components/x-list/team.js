import Component from '@ember/component';

export default Component.extend({
  tagName: "",
  hideDelete: false,
  actions: {
    onConfirm(message, action) {
      this.get('notifications').confirmAction(message, action);
    }
  }
});
