import { inject, Injectable } from "@angular/core";
import { MatDialog } from "@angular/material/dialog";

@Injectable({
    providedIn: 'root'
})

export class DialogService {
    readonly dialog = inject(MatDialog);

    openDialog(dialogComponent: any, dialogProps: any) {
        this.dialog.open(dialogComponent, dialogProps);
    }
}