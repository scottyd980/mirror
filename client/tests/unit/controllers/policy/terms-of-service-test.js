import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';

module('Unit | Controller | policy/terms-of-service', function(hooks) {
  setupTest(hooks);

  // Replace this with your real tests.
  test('it exists', function(assert) {
    let controller = this.owner.lookup('controller:policy/terms-of-service');
    assert.ok(controller);
  });
});
