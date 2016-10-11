import Ember from 'ember';
import UnauthenticatedRouteMixin from 'ember-simple-auth/mixins/unauthenticated-route-mixin';

const { Route, inject } = Ember;

export default Route.extend(UnauthenticatedRouteMixin);
