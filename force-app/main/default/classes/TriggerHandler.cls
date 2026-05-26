/**
 * @author                 :    narjes.b@gmail.com
 * Description             :    Trigger Handler
 * Last modified by        :    narjes.b@gmail.com
 * last modified Date      :    May 2026
 * 
 */


public virtual class TriggerHandler {

    public void run() {
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                beforeInsert();
            } else if (Trigger.isUpdate) {
                beforeUpdate();
            } else if (Trigger.isDelete) {
                beforeDelete();
            }
        }

        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                afterInsert();
            } else if (Trigger.isUpdate) {
                afterUpdate();
            } else if (Trigger.isDelete) {
                afterDelete();
            } else if (Trigger.isUndelete) {
                afterUndelete();
            }
        }
    }

    public virtual void beforeInsert() {
        return;
    }

    public virtual void beforeUpdate() {
        return;
    }

    public virtual void beforeDelete() {
        return;
    }

    public virtual void afterInsert() {
        return;
    }

    public virtual void afterUpdate() {
        return;
    }

    public virtual void afterDelete() {
        return;
    }

    public virtual void afterUndelete() {
        return;
    }
}