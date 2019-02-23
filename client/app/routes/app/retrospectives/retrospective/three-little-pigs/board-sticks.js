import Route from '@ember/routing/route';
import { hash } from 'rsvp';
import ENV from 'mirror/config/environment';

export default Route.extend({
  model() {
    const parent = this.modelFor('app.retrospectives.retrospective')

    return this.get('store').findRecord('retrospective', parent.retrospective.get('id'))
    .then((retrospective) => {
      return Promise.all([retrospective.get('team'), retrospective.get('feedbacks'), ]).then((results) => {
        const team = results[0],
              feedback = results[1];

        const sticksFeedback = this._shift(this._shuffle(feedback.filter((fb) => {
          return fb.get('category') === "stick";
        })));
        
        return team.get('members').then((team_members) => {
          return hash({
            retrospective,
            team,
            team_members,
            feedback: sticksFeedback
          });
        }).catch(() => { throw ENV.ERROR_CODES.not_found});
      },
      () => { throw ENV.ERROR_CODES.not_found; });
    }).catch(() => { throw ENV.ERROR_CODES.not_found });
  },
  _shuffle(array) {
    let currentIndex = array.length, temporaryValue, randomIndex;
    while (0 !== currentIndex) {
      randomIndex = Math.floor(Math.random() * currentIndex);
      currentIndex -= 1;

      temporaryValue = array[currentIndex];
      array[currentIndex] = array[randomIndex];
      array[randomIndex] = temporaryValue;
    }

    return array;
  },
  _shift(array) {
    const firstElement = array.findIndex((val) => {
      return val.get('state') === 1;
    });
    array.splice(0, 0, array.splice(firstElement, 1)[0]);
    return array;
  }
});