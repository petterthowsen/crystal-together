require "json"

module Together::Finetune::Create
  
  # Response from creating a fine-tuning job
  struct Response
    include JSON::Serializable

    getter id : String
    getter object : String
    getter model : String
    getter created_at : Int64
    getter finished_at : Int64?
    getter fine_tuned_model : String?
    getter organization_id : String
    getter result_files : Array(String)
    getter status : String
    getter validation_file : String?
    getter training_file : String
    getter hyperparameters : HyperParameters?
    getter error : String?
  end
end