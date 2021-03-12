Qaudio = {}

love.audio.setEffect('reverb', {
	type = 'reverb',
	gain = 0.3,
	decaytime = 1.0,
})


love.audio.setEffect('delay', {
	type = 'echo',
	volume = 0.05,
	delay = 0.12,
	tapdelay = 0.044,
	damping = 0.5,
	feedback = .3,
	spread = 1.0,
})


function Qaudio.load()
	bitDepth = 16
	samplingRate = 44100
	channelCount = 2
	bufferSize =  1024 -- at 60fps we need a buffer of minimum 44100/60 = 735
	pointer = 0
	sd = love.sound.newSoundData(bufferSize, samplingRate, bitDepth, channelCount)
	qs = love.audio.newQueueableSource(samplingRate, bitDepth, channelCount)

	qs:setEffect('reverb')
	qs:setEffect('delay')

	dspTime = 0.0

	fun = nil
end

function Qaudio.setCallback(f)
	fun = f
end

function Qaudio.update()
	if qs:getFreeBufferCount() == 0 then return end
	 local samplesToMix = bufferSize
	 for smp = 0, samplesToMix-1 do
		 local l,r = fun(dspTime)
		 sd:setSample(pointer,1, l)
		 sd:setSample(pointer,2, r)
		 pointer = pointer + 1
		 dspTime = dspTime + 1
		 if pointer >= sd:getSampleCount() then
			 pointer = 0
			 qs:queue(sd)
			 qs:play()
		 end
	 end
end