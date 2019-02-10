import RetrospectiveController from 'mirror/controllers/app/retrospectives/extends/retrospective';

export default RetrospectiveController.extend({
  current_feedback_count: 1,
  actions: {
    moveFeedback(feedback, direction) {
      const retrospective = this.get('model').parent.retrospective;

      const start_idx = 0,
            end_idx = feedback.length - 1;

      let new_idx;

      const active_idx = feedback.findIndex((fb) => {
        return fb.get('id') === retrospective.get('active_feedback.id');
      });

      if(active_idx === 0 && direction === -1) {
        new_idx = end_idx
      } else if(active_idx === end_idx && direction === 1) {
        new_idx = start_idx;
      } else {
        new_idx = active_idx + direction;
      }

      

      retrospective.set('active_feedback', feedback[new_idx]);
      
      retrospective.save().then(() => {
        this.set('current_feedback_count', new_idx + 1);
      });
    },
  }
});
