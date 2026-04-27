from django import forms


class EntryPointForm(forms.Form):
    rootid = forms.CharField(
        required=False,
        label='№ Паспорта',
        max_length=100,
    )
    name = forms.CharField(
        required=False,
        label='Название',
        max_length=255,
    )

    def clean(self):
        cleaned_data = super().clean()
        rootid = (cleaned_data.get('rootid') or '').strip()
        name = (cleaned_data.get('name') or '').strip()

        if not rootid and not name:
            raise forms.ValidationError('Укажите № Паспорта или Название.')
        if rootid and name:
            raise forms.ValidationError('Заполните только одно поле: № Паспорта или Название.')

        cleaned_data['rootid'] = rootid
        cleaned_data['name'] = name
        return cleaned_data
