import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';

module('Unit | Route | app/organizations/dashboard', function(hooks) {
  setupTest(hooks);

  test('it exists', function(assert) {
    let route = this.owner.lookup('route:app/organizations/dashboard');
    assert.ok(route);
  });
});
