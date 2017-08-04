import Ember from 'ember';
import RSVP from 'rsvp';
import config from '../../../config/environment';

const { inject } = Ember;

export default Ember.Route.extend({
    session: inject.service(),
    model() {
        let current_user = this.get('session.currentUser');

        return RSVP.hash({
            teams: current_user.get('teams').sortBy('id'),
            organizations: current_user.get('organizations').sortBy('id'),
            recent_retrospectives: current_user.get('teams').then((teams) => {
                let retros = teams.map((team) => {
                    return this.store.query('retrospective', {
                        filter: {
                            team: team.get('id')
                        }
                    })
                })

                return RSVP.allSettled(retros).then((retrospectives) => {
                    let retro_list = retrospectives.reduce((retro_arr, retrospective) => {
                        return retro_arr.concat(retrospective.value.toArray());
                    }, []);
                    
                    return retro_list.sortBy('updatedAt').reverse().slice(0,10);
                });
                
            })
        });
    },
    setupController(controller, model) {
        this._super(controller, model);

        let retrospectives = model.recent_retrospectives;

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
