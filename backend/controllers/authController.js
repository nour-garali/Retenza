const crypto = require('crypto');
const User = require('../models/User');
const Commerce = require('../models/Commerce');
const { generateToken, generateResetToken } = require('../utils/generateToken');
const asyncHandler = require('../utils/asyncHandler');

const buildAuthResponse = (user) => ({
  success: true,
  message: 'Success',
  data: {
    user: {
      id: user._id,
      email: user.email,
      role: user.role,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      commerce: user.commerce,
    },
    token: generateToken(user._id, user.role),
  },
});

exports.registerMerchant = asyncHandler(async (req, res) => {
  const { email, password, firstName, lastName, phone, commerceName, category } = req.body;

  const existing = await User.findOne({ email });
  if (existing) {
    return res.status(409).json({ success: false, message: 'Email already registered' });
  }

  const user = await User.create({
    email,
    password,
    firstName,
    lastName,
    phone,
    role: 'merchant',
  });

  const commerce = await Commerce.create({
    name: commerceName,
    category,
    merchant: user._id,
    status: 'pending',
    contact: { email, phone },
  });

  user.commerce = commerce._id;
  await user.save();

  res.status(201).json({
    ...buildAuthResponse(user),
    message: 'Merchant registered successfully',
  });
});

exports.registerClient = asyncHandler(async (req, res) => {
  const { email, password, firstName, lastName, phone } = req.body;

  const existing = await User.findOne({ email });
  if (existing) {
    return res.status(409).json({ success: false, message: 'Email already registered' });
  }

  const user = await User.create({
    email,
    password,
    firstName,
    lastName,
    phone,
    role: 'client',
  });

  await Client.create({
    firstName,
    lastName,
    email,
    phone,
    user: user._id,
  });

  res.status(201).json({
    ...buildAuthResponse(user),
    message: 'Client registered successfully',
  });
});

exports.login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  const user = await User.findOne({ email }).select('+password');
  if (!user || !(await user.comparePassword(password))) {
    return res.status(401).json({ success: false, message: 'Invalid email or password' });
  }

  if (!user.isActive) {
    return res.status(403).json({ success: false, message: 'Account is deactivated' });
  }

  res.json({
    ...buildAuthResponse(user),
    message: 'Login successful',
  });
});

exports.forgotPassword = asyncHandler(async (req, res) => {
  const { email } = req.body;

  const user = await User.findOne({ email });
  if (!user) {
    return res.json({
      success: true,
      message: 'If the email exists, a reset link has been sent.',
    });
  }

  const resetToken = generateResetToken();
  user.resetPasswordToken = crypto.createHash('sha256').update(resetToken).digest('hex');
  user.resetPasswordExpires = Date.now() + 3600000;
  await user.save();

  res.json({
    success: true,
    message: 'Password reset token generated.',
    data: {
      resetToken,
      expiresIn: process.env.RESET_TOKEN_EXPIRES_IN || '1h',
      note: 'In production, this token would be sent via email.',
    },
  });
});

exports.resetPassword = asyncHandler(async (req, res) => {
  const { token, newPassword } = req.body;

  const hashedToken = crypto.createHash('sha256').update(token).digest('hex');
  const user = await User.findOne({
    resetPasswordToken: hashedToken,
    resetPasswordExpires: { $gt: Date.now() },
  }).select('+password');

  if (!user) {
    return res.status(400).json({ success: false, message: 'Invalid or expired reset token' });
  }

  user.password = newPassword;
  user.resetPasswordToken = undefined;
  user.resetPasswordExpires = undefined;
  await user.save();

  res.json({
    success: true,
    message: 'Password reset successful',
    data: { token: generateToken(user._id, user.role) },
  });
});

exports.getMe = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id).populate('commerce');
  res.json({ success: true, data: { user } });
});
