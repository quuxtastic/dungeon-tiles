exports.roll_die=(d) -> Math.floor(Math.random()*d)+1

exports.roll_fudge_die=() -> exports.roll_die(3)-2

exports.roll_exploding_die=(d,x) ->
  rolls=[]
  rolls.sum=0

  roll=Number.MAX_VALUE
  while roll>=x
    roll=exports.roll_die d
    rolls.push roll
    rolls.sum+=roll

  return rolls
