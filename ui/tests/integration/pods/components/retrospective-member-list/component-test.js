import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('retrospective-member-list', 'Integration | Component | retrospective member list', {
  integration: true
});

test('it renders', function(assert) {
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });

  this.render(hbs`{{retrospective-member-list}}`);

  assert.equal(this.$().text().trim(), '');

  // Template block usage:
  this.render(hbs`
    {{#retrospective-member-list}}
      template block text
    {{/retrospective-member-list}}
  `);

  assert.equal(this.$().text().trim(), 'template block text');
});
