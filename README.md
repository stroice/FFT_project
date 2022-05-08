# Low Area/ High Frequency FFT
This project started with the objective of obtaining a low power FFT to be synthesize for ASIC technology utilizing RAM memories as delays for achiving this objective.
However, once the project was done, it was observed that an extreamly high frequency could be obtained from this architecture just by doing some simple modifications and synthesizing the architecture in a right way, so apart from the FFT_Low_power architecture, two other hight frequency architectures are presented which involves those small modifications for achieving that objectives.

Note that when synthesizing for Low_power FFT, the normal rotators and UD_CORDIC is used and when synthesizing the High frequency FFTs, the high freqeuncy and UD_CORDIC will be required.

About the High frequency architectures, we present 2 kinds. One which does not put pipleining inside the FFT delays and another one which does. The one with pipeling allows the architecture to isolate the read time of the memory which leads to a higher frequency, however, some extra area and consumption will be added as trade off.
