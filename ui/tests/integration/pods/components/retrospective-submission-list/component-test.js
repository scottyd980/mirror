import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('retrospective-submission-list', 'Integration | Component | retrospective submission list', {
  integration: true
});

test('it renders', function(assert) {
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });

  this.render(hbs`{{retrospective-submission-list}}`);

  assert.equal(this.$().text().trim(), '');

  // Template block usage:
  this.render(hbs`
    {{#retrospective-submission-list}}
      template block text
    {{/retrospective-submission-list}}
  `);

  assert.equal(this.$().text().trim(), 'template block text');
});
