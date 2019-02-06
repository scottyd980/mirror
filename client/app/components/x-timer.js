import Component from '@ember/component';
import { inject as service } from '@ember/service';
import { computed } from '@ember/object';

export default Component.extend({
  tagName: "",
  clock: service(),
  start: null,
  didInsertElement() {
    this.set('start', this.get('clock.date'));
    this.set('isStarted', true);
  },
  timer: computed('clock.date', function () {
    if (this.get('isStarted')) {
      const ms = this.get('clock.date') - this.get('start');

      const seconds = ("0" + parseInt((ms / 1000) % 60)).slice(-2),
        minutes = ("0" + parseInt((ms / (1000 * 60)) % 60)).slice(-2),
        hours = ("0" + parseInt((ms / (1000 * 60 * 60)) % 24)).slice(-2);

      if (hours === "00") {
        return `${minutes}:${seconds}`;
      } else {
        return `${hours}:${minutes}:${seconds}`;
      }
    }

    return "00:00";
  })
});
