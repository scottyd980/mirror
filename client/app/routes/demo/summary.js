import RetrospectiveRoute from 'mirror/routes/demo/extends/retrospective';
import ENV from 'mirror/config/environment';
import { get } from '@ember/object';

export default RetrospectiveRoute.extend({
  model() {
    const allScores = ENV.DEMO.user_score.concat(ENV.DEMO.retrospectives[5].scores);
    const positiveFeedback = ENV.DEMO.retrospectives[3].feedbacks;
    const negativeFeedback = ENV.DEMO.retrospectives[2].feedbacks;
    const allFeedback = ENV.DEMO.user_feedback.concat(positiveFeedback.concat(negativeFeedback));
    
    return {
      team_members: ENV.DEMO.team_members,
      retrospective: ENV.DEMO.retrospectives[6],
      team: ENV.DEMO.team,
      scores: allScores,
      feedback: allFeedback
    }
  },
  setupController(controller, model) {
    this._super(...arguments);

    const scores = model.scores.sortBy('score');

    const average = +parseFloat(scores.reduce((total, score) => {
      return total + get(score, 'score');
    }, 0) / scores.length).toFixed(1);

    controller.set('low_score', (typeof scores[0] !== "undefined" ? scores[0] : { score: "N/A" }));
    controller.set('high_score', (typeof scores[scores.length - 1] !== "undefined" ? scores[scores.length - 1] : { score: "N/A" }));
    controller.set('average_score', average || "N/A");
  }
});
