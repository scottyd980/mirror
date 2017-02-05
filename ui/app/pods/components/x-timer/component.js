import Ember from 'ember';

export default Ember.Component.extend({
    clock: Ember.inject.service('moderator-clock'),
    start: null,
    classNames: ['timer'],
    didInsertElement() {
        this.set('start', this.get('clock.date'));
        this.set('isStarted', true);
    },
    timer: Ember.computed('clock.date', function() {
        if(this.get('isStarted')) {
            let ms = this.get('clock.date') - this.get('start');

            let milliseconds = parseInt((ms%1000)/100),
                seconds = ("0" + parseInt((ms/1000)%60)).slice(-2),
                minutes = ("0" + parseInt((ms/(1000*60))%60)).slice(-2),
                hours = ("0" + parseInt((ms/(1000*60*60))%24) + "0").slice(-2);

            // return {
            //     hours: hours,
            //     minutes: minutes,
            //     seconds: seconds
            // };
            if(hours == "00") {
                return `${minutes}:${seconds}`;
            } else {
                return `${hours}:${minutes}:${seconds}`;
            }
        }

        // return {
        //     hours: "00",
        //     minutes: "00",
        //     seconds: "00"
        // };

        return "00:00";
    })
});
