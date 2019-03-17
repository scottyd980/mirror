import { module, test } from 'qunit';
import { visit, currentURL, fillIn, click, find, waitFor, findAll } from '@ember/test-helpers';
import { setupApplicationTest } from 'ember-qunit';
import setupMirage from 'ember-cli-mirage/test-support/setup-mirage';
import scenarios from "mirror/mirage/scenarios";

module('Acceptance | auth/register', function(hooks) {
  setupApplicationTest(hooks);
  setupMirage(hooks);

  test('visiting /auth/register', async function(assert) {
    await visit('/auth/register');

    assert.equal(currentURL(), '/auth/register');
  });

  test('register works when all fields are provided valid data', async function(assert) {
    scenarios.auth.register_success(server);

    await visit('/auth/register');
    await fillIn('#register-username', 'test');
    await fillIn('#register-email', 'test@test.com');
    await fillIn('#register-password', 'password');
    await fillIn('#register-password-confirmation', 'password');
    await click('button[type="submit"]');
    await waitFor('.post-login');

    assert.equal(currentURL(), '/app');
  })

  test('register fails when invalid data is entered', async function(assert) {
    scenarios.auth.register_failure(server);

    await visit('/auth/register');
    await click('button[type="submit"]');

    assert.ok(find(".alert-danger"))
    findAll('.form-group').forEach((element) => {
      assert.ok(element.classList.contains('has-error'));
    });
    assert.notEqual(currentURL(), '/app');
  });
});
