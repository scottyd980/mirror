import RetrospectiveController from 'mirror/controllers/app/retrospectives/extends/retrospective';
import { computed } from '@ember/object';

export default RetrospectiveController.extend({
  current_feedback_count: 1,
  active_feedback: computed('model.feedback.@each.state', function() {
    const feedback = this.get('model.feedback');
    return feedback.find((fb) => {
      return fb.get('state') === 1;
    })
  }),
  card_state: computed('current_feedback_count', 'model.feedback.[]', function() {
    return `${this.get('current_feedback_count')}/${this.get('model.feedback').length}`;
  }),
  actions: {
    moveFeedback(feedback, direction) {
      const start_idx = 0,
            end_idx = feedback.length - 1;

      let new_idx;

      const active_idx = feedback.findIndex((fb) => {
        return fb.get('state') === 1;
      });

      if(active_idx === 0 && direction === -1) {
        new_idx = end_idx
      } else if(active_idx === end_idx && direction === 1) {
        new_idx = start_idx;
      } else {
        new_idx = active_idx + direction;
      }

      feedback.forEach((fb) => {
        fb.set('state', 0);
      });

      feedback[new_idx].set('state', 1);

      const updated_feedback = feedback.map((fb) => {
        return fb.save();
      })

      Promise.all(updated_feedback).then(() => {
        this.set('current_feedback_count', new_idx + 1);
      });
    },
  }
});
