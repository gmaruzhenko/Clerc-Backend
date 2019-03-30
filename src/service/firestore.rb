require 'google/cloud/firestore'
require_relative '../model/Vendor'

# Module for Firebase Firestore methods
module Firestore

  # Names of our firebase data structure
  VENDORS_COL_NAME = 'vendors'.freeze
  VENDOR_BACKEND_COL_NAME = 'backend'.freeze
  VENDOR_BACKEND_STRIPE_DOC_NAME = 'stripe'.freeze

  #
  # Saves a vendor to firestore and returns the firestore ID
  #
  # @param [Vendor] vendor to save
  # @param [Object] firestore initialized firestore object
  # @return [String] firestore id if successfully saved
  def self.save_vendor(vendor, firestore)
    # Reference to the vendors collection
    vendors_ref = firestore.col VENDORS_COL_NAME
    basic_vendor_data = {
      name: vendor.name
    }
    puts "Saving vendor: #{vendor.name}"

    added_vendor_ref = vendors_ref.doc
    added_vendor_ref.set basic_vendor_data
    puts "Successfully saved vendor #{vendor.name}
          with ID: #{added_vendor_ref.document_id}."

    # Now save all the stripe information
    vendor_stripe_ref = added_vendor_ref.col(VENDOR_BACKEND_COL_NAME)
                                        .doc(VENDOR_BACKEND_STRIPE_DOC_NAME)
    stripe_data = {
      stripe_publishable_key: vendor.stripe_publishable_key,
      stripe_user_id: vendor.stripe_user_id,
      stripe_refresh_token: vendor.stripe_refresh_token,
      stripe_access_token: vendor.stripe_access_token
    }
    vendor_stripe_ref.set stripe_data
    puts 'Successfully saved vendor Stripe data'

    # Return the firebase ID
    added_vendor_ref.document_id
  end

  #
  # Loads and returns a vendor from firestore with the given ID
  # Returns nil if the vendor does not exist
  #
  # @param [String] id - firestore id for the vendor
  # @param [Object] firestore - initialized firestore object
  # @return [Vendor] - a vendor object or nil if not found
  def self.load_vendor(id, firestore)

    vendor_id = id

    # First get the main document - if this exists then the vendor exists
    vendor_main_doc_ref  = firestore.doc "#{VENDORS_COL_NAME}/#{vendor_id}"
    vendor_main_doc = vendor_main_doc_ref.get
    if vendor_main_doc.exists?
      vendor_name = vendor_main_doc.data[:name]
    else
      puts "Vendor with id #{vendor_id} does not exist"
      return nil
    end

    # Now get the stripe information
    vendor_str_doc_ref = vendor_main_doc_ref.col(VENDOR_BACKEND_COL_NAME)
                                            .doc(VENDOR_BACKEND_STRIPE_DOC_NAME)
    vendor_str_doc = vendor_str_doc_ref.get
    if vendor_str_doc.exists?
      stripe_data = vendor_str_doc.data
      vendor_str_pub_key = stripe_data[:stripe_publishable_key]
      vendor_str_user_id = stripe_data[:stripe_user_id]
      vendor_str_ref_tok = stripe_data[:stripe_refresh_token]
      vendor_str_acc_tok = stripe_data[:stripe_access_token]
    else
      puts "Vendor with id #{vendor_id} does not have Stripe info"
      return nil
    end

    # return new vendor object
    Vendor.new(vendor_id, vendor_name, vendor_str_pub_key,
               vendor_str_user_id, vendor_str_ref_tok, vendor_str_acc_tok)
  end
end
