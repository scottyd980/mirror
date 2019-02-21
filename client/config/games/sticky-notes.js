module.exports = function() {
  return {
    type_id: 1,
    states: ["start", "feedback", "sticky-notes.board-negative", "sticky-notes.board-positive", "score", "aggregate", "summary"],
    min_complete_state: 6,
    feedback: [
      {
        name: "negative",
        idPrefix: "went-poorly",
        label: "What could be improved?",
        type: "negative",
        value: ""
      },
      {
        name: "positive",
        idPrefix: "went-well",
        label: "What went well?",
        type: "positive",
        value: ""
      }
    ]
  };
}