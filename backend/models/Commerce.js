const mongoose = require('mongoose');

const openingHourSchema = new mongoose.Schema(
  {
    day: {
      type: String,
      enum: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],
      required: true,
    },
    open: { type: String, default: '09:00' },
    close: { type: String, default: '18:00' },
    isClosed: { type: Boolean, default: false },
  },
  { _id: false }
);

const commerceSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Commerce name is required'],
      trim: true,
    },
    description: {
      type: String,
      trim: true,
    },
    category: {
      type: String,
      required: [true, 'Category is required'],
      trim: true,
    },
    logo: {
      type: String,
      default: null,
    },
    contact: {
      email: { type: String, trim: true, lowercase: true },
      phone: { type: String, trim: true },
      address: { type: String, trim: true },
      city: { type: String, trim: true },
      postalCode: { type: String, trim: true },
    },
    openingHours: [openingHourSchema],
    loyaltyProgram: {
      type: {
        type: String,
        enum: ['points', 'stamps', 'cashback'],
        default: 'points',
      },
      pointsPerEuro: { type: Number, default: 1, min: 0 },
      amountPerPoints: { type: Number, default: 10 },   // X DT = Y points (custom rate)
      stampsRequired: { type: Number, default: 10, min: 1 },
      cashbackPercentage: { type: Number, default: 5, min: 0, max: 100 },
      rewardDescription: { type: String, default: 'Reward on completion' },
      rewardName: { type: String, default: '' },
      rewardThreshold: { type: Number, default: 100 },  // points/stamps needed for reward
    },
    brandColor: { type: String, default: '#D73E26' },
    coverImage: { type: String, default: null },
    website: { type: String, default: null },
    notifications: {
      receiveClientNotifications: { type: Boolean, default: true },
      autoSendPromos: { type: Boolean, default: true },
    },
    status: {
      type: String,
      enum: ['active', 'suspended', 'pending'],
      default: 'pending',
    },
    isConfigured: {
      type: Boolean,
      default: false,
    },
    merchant: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    merchantCode: {
      type: String,
      unique: true,
      sparse: true, // Uniquement défini une fois le commerce activé
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Commerce', commerceSchema);
