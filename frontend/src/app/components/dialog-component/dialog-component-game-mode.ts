import { Component, inject } from "@angular/core";
import { MAT_DIALOG_DATA, MatDialogActions, MatDialogContent, MatDialogRef } from "@angular/material/dialog";

@Component({
    selector: 'dialog-component-game-mode',
    templateUrl: 'dialog-component-game-mode.html',
    imports: [MatDialogContent, MatDialogActions],
    styleUrl: 'dialog-component.scss'

})
export class DialogComponentGameMode {
    readonly dialogRef = inject(MatDialogRef<DialogComponentGameMode>);
    readonly data = inject<any>(MAT_DIALOG_DATA);
    readonly dialogTitle = this.data.dialogTitle;
    readonly dialogText = this.data.dialogText;

    handleClickAction = this.data.handleClickAction;

    onNoClick(): void {
        this.dialogRef.close();
    }

    handleClick(): void {
        this.handleClickAction();
        this.dialogRef.close();
    }
}