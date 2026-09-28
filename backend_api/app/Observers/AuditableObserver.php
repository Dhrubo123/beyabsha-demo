<?php
namespace App\Observers;
use App\Models\AuditLog;use Illuminate\Database\Eloquent\Model;
class AuditableObserver{
 public function created(Model $model):void{$this->write($model,'created',$model->getAttributes());}
 public function updated(Model $model):void{$this->write($model,'updated',$model->getChanges());}
 public function deleted(Model $model):void{$this->write($model,'deleted',[]);}
 private function write(Model $model,string $action,array $changes):void{$user=auth()->user();$businessId=$model->getAttribute('business_id')??$user?->business_id;if(!$businessId)return;unset($changes['password'],$changes['remember_token'],$changes['updated_at'],$changes['created_at']);AuditLog::create(['business_id'=>$businessId,'user_id'=>$user?->id,'event'=>class_basename($model).'.'.$action,'subject_type'=>$model::class,'subject_id'=>$model->getKey(),'properties'=>$changes?:null,'ip_address'=>request()?->ip()]);}
}
