import Ember from 'ember';
import RSVP from 'rsvp';
import config from '../../../../../../config/environment';

export default Ember.Route.extend({
    model() {
        var _this = this;
        return RSVP.hash({
            team: _this.modelFor('app.teams.team'),
            retrospectives: _this.store.query('retrospective', {
                filter: {
                    team: _this.modelFor('app.teams.team').get('id')
                }
            })
        });
    },
    setupController(controller, model) {
        this._super(controller, model);
        
        let retrospectives = model.retrospectives;

        retrospectives.map((retro) => {
            return retro.get('scores').then((scores) => {
                let averageScore = Math.round((scores.reduce((total, score) => {
                    return total + score.get('score');
                }, 0) / scores.length) * 10) / 10;

                let scoreType = function() {
                    if(averageScore) {
                        if(averageScore > 6.67) {
                            return "success";
                        } else if(averageScore > 3.34) {
                            return "warning";
                        } else {
                            return "danger";
                        }
                    } else {
                        return "info";
                    }
                }();

                retro.set('averageScore', averageScore);
                retro.set('scoreType', scoreType);
            });
        });
    }
});