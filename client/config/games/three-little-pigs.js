module.exports = function() {
  return {
    type_id: 2,
    states: ["start", "feedback", "three-little-pigs.board-straw", "three-little-pigs.board-sticks", "three-little-pigs.board-bricks", "score", "aggregate", "summary"],
    min_complete_state: 7,
    feedback: [
      {
        name: "straw",
        idPrefix: "house-of-straw",
        label: "House of straw - what is something that could fall over at any second?",
        type: "straw",
        value: ""
      },
      {
        name: "stick",
        idPrefix: "house-of-sticks",
        label: "House of sticks - what is something that is pretty well-built, but can use some work?",
        type: "stick",
        value: ""
      },
      {
        name: "brick",
        idPrefix: "house-of-bricks",
        label: "House of bricks - what is something the team does that's rock solid?",
        type: "brick",
        value: ""
      }
    ]
  };
}