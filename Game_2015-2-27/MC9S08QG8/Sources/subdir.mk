################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.local

# Add inputs and outputs from these tool invocations to the build variables 
ASM_SRCS += \
../Sources/Animation.asm \
../Sources/LCD.asm \
../Sources/LED_pattern.asm \
../Sources/MCUinit.asm \
../Sources/keyboard.asm \
../Sources/main.asm \

ASM_SRCS_QUOTED += \
"../Sources/Animation.asm" \
"../Sources/LCD.asm" \
"../Sources/LED_pattern.asm" \
"../Sources/MCUinit.asm" \
"../Sources/keyboard.asm" \
"../Sources/main.asm" \

OBJS += \
./Sources/Animation_asm.obj \
./Sources/LCD_asm.obj \
./Sources/LED_pattern_asm.obj \
./Sources/MCUinit_asm.obj \
./Sources/keyboard_asm.obj \
./Sources/main_asm.obj \

ASM_DEPS += \
./Sources/Animation_asm.d \
./Sources/LCD_asm.d \
./Sources/LED_pattern_asm.d \
./Sources/MCUinit_asm.d \
./Sources/keyboard_asm.d \
./Sources/main_asm.d \

OBJS_QUOTED += \
"./Sources/Animation_asm.obj" \
"./Sources/LCD_asm.obj" \
"./Sources/LED_pattern_asm.obj" \
"./Sources/MCUinit_asm.obj" \
"./Sources/keyboard_asm.obj" \
"./Sources/main_asm.obj" \

ASM_DEPS_QUOTED += \
"./Sources/Animation_asm.d" \
"./Sources/LCD_asm.d" \
"./Sources/LED_pattern_asm.d" \
"./Sources/MCUinit_asm.d" \
"./Sources/keyboard_asm.d" \
"./Sources/main_asm.d" \

OBJS_OS_FORMAT += \
./Sources/Animation_asm.obj \
./Sources/LCD_asm.obj \
./Sources/LED_pattern_asm.obj \
./Sources/MCUinit_asm.obj \
./Sources/keyboard_asm.obj \
./Sources/main_asm.obj \


# Each subdirectory must supply rules for building sources it contributes
Sources/Animation_asm.obj: ../Sources/Animation.asm
	@echo 'Building file: $<'
	@echo 'Executing target #1 $<'
	@echo 'Invoking: HCS08 Assembler'
	"$(HC08ToolsEnv)/ahc08" -ArgFile"Sources/Animation.args" -Objn"Sources/Animation_asm.obj" "$<" -Lm="$(@:%.obj=%.d)" -LmCfg=xilmou
	@echo 'Finished building: $<'
	@echo ' '

Sources/%.d: ../Sources/%.asm
	@echo 'Regenerating dependency file: $@'
	
	@echo ' '

Sources/LCD_asm.obj: ../Sources/LCD.asm
	@echo 'Building file: $<'
	@echo 'Executing target #2 $<'
	@echo 'Invoking: HCS08 Assembler'
	"$(HC08ToolsEnv)/ahc08" -ArgFile"Sources/LCD.args" -Objn"Sources/LCD_asm.obj" "$<" -Lm="$(@:%.obj=%.d)" -LmCfg=xilmou
	@echo 'Finished building: $<'
	@echo ' '

Sources/LED_pattern_asm.obj: ../Sources/LED_pattern.asm
	@echo 'Building file: $<'
	@echo 'Executing target #3 $<'
	@echo 'Invoking: HCS08 Assembler'
	"$(HC08ToolsEnv)/ahc08" -ArgFile"Sources/LED_pattern.args" -Objn"Sources/LED_pattern_asm.obj" "$<" -Lm="$(@:%.obj=%.d)" -LmCfg=xilmou
	@echo 'Finished building: $<'
	@echo ' '

Sources/MCUinit_asm.obj: ../Sources/MCUinit.asm
	@echo 'Building file: $<'
	@echo 'Executing target #4 $<'
	@echo 'Invoking: HCS08 Assembler'
	"$(HC08ToolsEnv)/ahc08" -ArgFile"Sources/MCUinit.args" -Objn"Sources/MCUinit_asm.obj" "$<" -Lm="$(@:%.obj=%.d)" -LmCfg=xilmou
	@echo 'Finished building: $<'
	@echo ' '

Sources/keyboard_asm.obj: ../Sources/keyboard.asm
	@echo 'Building file: $<'
	@echo 'Executing target #5 $<'
	@echo 'Invoking: HCS08 Assembler'
	"$(HC08ToolsEnv)/ahc08" -ArgFile"Sources/keyboard.args" -Objn"Sources/keyboard_asm.obj" "$<" -Lm="$(@:%.obj=%.d)" -LmCfg=xilmou
	@echo 'Finished building: $<'
	@echo ' '

Sources/main_asm.obj: ../Sources/main.asm
	@echo 'Building file: $<'
	@echo 'Executing target #6 $<'
	@echo 'Invoking: HCS08 Assembler'
	"$(HC08ToolsEnv)/ahc08" -ArgFile"Sources/main.args" -Objn"Sources/main_asm.obj" "$<" -Lm="$(@:%.obj=%.d)" -LmCfg=xilmou
	@echo 'Finished building: $<'
	@echo ' '


