import RetrospectiveRoute from 'mirror/routes/demo/extends/retrospective';
import ENV from 'mirror/config/environment';
import { set } from '@ember/object';
import { schedule } from '@ember/runloop';

export default RetrospectiveRoute.extend({
  model() {
    const allFeedback = ENV.DEMO.user_feedback.concat(ENV.DEMO.retrospectives[3].feedbacks);
    const positiveFeedback = this._shuffle(allFeedback.filter((fb) => {
      return fb.category === "positive";
    }));

    return {
      retrospective: ENV.DEMO.retrospectives[3],
      team: ENV.DEMO.team,
      team_members: ENV.DEMO.team_members,
      feedback: positiveFeedback
    }
  },
  setupController(controller, model) {
    this._super(...arguments);
    model.feedback.forEach((fb, index) => {
      if(index === 0) { 
        set(fb, 'state', 1) ;
      } else {
        set(fb, 'state', 0);
      }
    })

    schedule('afterRender', this, function() {
      controller.start_tour(ENV.TOUR.positive);
    });
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
  }
});