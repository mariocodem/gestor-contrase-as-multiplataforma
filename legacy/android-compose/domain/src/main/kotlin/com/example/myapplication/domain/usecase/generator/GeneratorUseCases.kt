package com.example.myapplication.domain.usecase.generator

import com.example.myapplication.domain.generator.PasswordGenerator
import com.example.myapplication.domain.generator.PasswordStrengthEstimator
import com.example.myapplication.domain.model.GeneratedPassword
import com.example.myapplication.domain.model.PasswordOptions
import com.example.myapplication.domain.model.PasswordStrength
import javax.inject.Inject

class GeneratePasswordUseCase @Inject constructor(
    private val generator: PasswordGenerator,
    private val estimator: PasswordStrengthEstimator,
) {
    /** The strength describes the settings, not this string: that is what an attacker faces. */
    operator fun invoke(options: PasswordOptions): GeneratedPassword =
        GeneratedPassword(value = generator.generate(options), strength = estimator.estimate(options))
}

class EvaluatePasswordStrengthUseCase @Inject constructor(private val estimator: PasswordStrengthEstimator) {
    operator fun invoke(password: String): PasswordStrength = estimator.estimate(password)
}
