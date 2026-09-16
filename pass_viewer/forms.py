from django import forms
from django.contrib.auth.forms import AuthenticationForm


class RussianAuthenticationForm(AuthenticationForm):
    error_messages = {
        **AuthenticationForm.error_messages,
        "invalid_login": (
            "Укажите правильные имя пользователя и пароль. Оба поля могут быть чувствительны к регистру."
        ),
        "inactive": "Эта учётная запись неактивна.",
    }


class RegistrationRequestForm(forms.Form):
    """Заявка на регистрацию пользователя: поля листа «Перечень» шаблона
    «Шаблон для добавления пользователей.xlsx» (№ п/п присваивается при выгрузке)."""

    REQUIRED_ERROR = "Заполните это поле."
    MAX_LENGTH_ERROR = "Не более {limit_value} символов."
    EMAIL_INVALID_ERROR = "Укажите корректный адрес электронной почты."

    executive_authority = forms.CharField(
        label="Орган исполнительной власти",
        max_length=255,
        widget=forms.TextInput(
            attrs={
                "list": "registration-executive-authority-options",
                "autocomplete": "off",
            }
        ),
        error_messages={"required": REQUIRED_ERROR, "max_length": MAX_LENGTH_ERROR},
    )
    institution_name = forms.CharField(
        label="Наименование учреждения",
        max_length=255,
        widget=forms.TextInput(
            attrs={
                "list": "registration-institution-options",
                "autocomplete": "off",
            }
        ),
        error_messages={"required": REQUIRED_ERROR, "max_length": MAX_LENGTH_ERROR},
    )
    representative_name = forms.CharField(
        label="ФИО ответственного представителя",
        max_length=255,
        error_messages={"required": REQUIRED_ERROR, "max_length": MAX_LENGTH_ERROR},
    )
    position = forms.CharField(
        label="Должность",
        max_length=255,
        error_messages={"required": REQUIRED_ERROR, "max_length": MAX_LENGTH_ERROR},
    )
    phone = forms.CharField(
        label="Контактный телефон",
        max_length=50,
        widget=forms.TextInput(attrs={"type": "tel"}),
        error_messages={"required": REQUIRED_ERROR, "max_length": MAX_LENGTH_ERROR},
    )
    email = forms.EmailField(
        label="Адрес электронной почты",
        max_length=254,
        widget=forms.EmailInput(attrs={"autocomplete": "email"}),
        error_messages={
            "required": REQUIRED_ERROR,
            "invalid": EMAIL_INVALID_ERROR,
            "max_length": MAX_LENGTH_ERROR,
        },
    )

    def clean(self):
        cleaned_data = super().clean()
        for field_name in (
            "executive_authority",
            "institution_name",
            "representative_name",
            "position",
            "phone",
            "email",
        ):
            value = cleaned_data.get(field_name)
            if value:
                cleaned_data[field_name] = value.strip()
        return cleaned_data


class EntryPointForm(forms.Form):
    rootid = forms.CharField(
        required=False,
        label="№ Паспорта",
        max_length=100,
    )
    name = forms.CharField(
        required=False,
        label="Название",
        max_length=255,
    )

    def clean(self):
        cleaned_data = super().clean()
        rootid = (cleaned_data.get("rootid") or "").strip()
        name = (cleaned_data.get("name") or "").strip()

        if not rootid and not name:
            raise forms.ValidationError("Укажите № Паспорта или Название.")
        if rootid and name:
            raise forms.ValidationError("Заполните только одно поле: № Паспорта или Название.")

        cleaned_data["rootid"] = rootid
        cleaned_data["name"] = name
        return cleaned_data
