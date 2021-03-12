# neurons

Simulates a dynamics neural network at audio rate.

Each neuron has connections with random weights, drawn as directed edges.

Each time step:
 - propagate all outputs * weights to inputs
 - sum all the input connections at every neuron
 - this input is lowpass-filtered with a different frequency for every neuron
 - this signal is then put through a nonlinearity
 - this is the output of the neuron
  
  the nonlinearity is a tanh with some soft threshold around zero

CONTROLS

mouse: 
 - click to drag around neuron (doesnt do anything)
 - left/right movement changes the individual frequencies
 - up/down scales the total weight (you can think of this as some global activation)

keyboard
 - m : generate new network topology
 - n : generate only new weights/frequencies
 - b : add some small random offset to all weights
 - v : only generate new frequencies
 - r : kickstart the network (useful for when theres no signal anymore)
      
